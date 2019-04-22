# Use Case 1 : Fundamental Analysis

## Note
- Root Directory = /kynetic
- Blueprint = single-container-kylin
- MySQL IP = 172.20.0.5
- Master Node IP = 172.20.0.2

## Prerequisite
- Docker is installed
- Single Container Kylin Docker Image is built
- ODBC Driver is installed on client computer | [Download](https://kyligence.io/resources/kyligence-odbc-driver-for-apache-kylin-2/)
## Steps

### Docker Image Setup
1. Set up single-container-kylin HDP cluster
```bash
docker-compose -f ./examples/compose/single-container-kylin.yml up
```

2. Submit amabari blueprint to start creating cluster
```
sh submit-blueprint.sh single-container-kylin
```

### Configure Master Node for Hive View and Kylin

1. Access into master node
```bash
docker exec -it compose_master0.dev_1 bash
```

2. Switch user and create necessary folder in HDFS
```bash
su - hdfs
hdfs dfs -mkdir /user/root /kylin /user/admin
hdfs dfs -chown root /user/root /kylin
hdfs dfs -chown admin /user/admin
```

3. Open Kylin Configuration File
```
cd $KYLIN_HOME/conf
vi kylin_job_conf_inmem.xml
```

4. Update the attribtes as follows
```
mapreduce.map.java.opts = -Xmx410m
mapreduce.map.memory.mb = 512
```

5. Start up Kylin
```bash
$KYLIN_HOME/bin/kylin.sh start
```

### Preparing Fundamental Data
I have decided to collect data from stockpup as they provided quarterly
fundamental data and easy to be scraped

1. Prepare the list of ticker | [LIST_COMP-01.txt]()
2. Scrap Data from stockpup | [./fundamental/]()
```bash
scrap-01.sh
```
3. Since there are files that are not being scraped properly, a bash command is
   used to get the list of ticker that are not being scraped properly |
   [LIST_COMP-01.txt]()
```bash
scrap-02.sh
```
4. Merging all fundamental data into one file | [fundamental-raw.csv]()
```bash
sh merge.sh
```
5. Edit and prepare table with the following columns

  | Column Name         | Previous Columne Name          | Notes                                              |
  |---------------------|--------------------------------|----------------------------------------------------|
  | index               | Not Exist                      | computed through [append.sh]()                     |
  | ticker              | Not Exist                      | computed through [merge.sh]()                      |
  | year                | Not Exist                      | `==LEFT(TEXT(quarter_end,"yyyy"),4)`               |
  | quarter             | Not Exist                      | computed through [append.sh]()                     |
  | quarter_end         | Quarter end                    |                                                    |
  | assets              | Assets                         |                                                    |
  | current-assets      | Current Assets                 |                                                    |
  | liabilities         | Liabilities                    |                                                    |
  | current liabilities | Current Liabilities            |                                                    |
  | shareholder_equity  | Shareholder equity             |                                                    |
  | preferred_equity    | Preferred equity               |                                                    |
  | goodwill            | Goodwill & intangibles         |                                                    |
  | long_debt           | Long-term debt                 |                                                    |
  | revenue             | Revenue                        |                                                    |
  | earning             | Earnings                       |                                                    |
  | eps                 | EPS diluted                    | - EPS Diluted                                      |
  | cash                | Cash at end of period          |                                                    |
  | price               | Price                          |                                                    |
  | roe                 | ROE                            |                                                    |
  | roa                 | ROA                            |                                                    |
  | pe_ratio            | Existed but discarded          |                                                    |
  | de_ratio            | Long-term debt to equity ratio |                                                    |
  | current_ratio       | Current Ratio                  |                                                    |
  | cash_ratio          | Not Exist                      |                                                    |
  | profit_margin       | Not Exist                      | = `IF(ISNUMBER(earning/revenue),earing/revenue,0)` |
  | nta                 | Not Exist                      | = assets - goodwill - liabilities                  |
  | pnta_ratio          | Not Exist                      | = `IF(ISNUMBER(price/nta),price/nta)`              |

6. Convert all 'None' value to 0
7. Compute column index and quarter
```bash
python append.py
```
### Preparing Company Profile Data
1. Getting US Ticker Profile Data | [Link](https://www.kaggle.com/usfundamentals/us-stocks-fundamentals)
2. Update and output the table as the following schema
3. Since this table acts as look up table, it need to containes every Ticker
   existed in Fundamental Table, the list of missing ticker is being added to
   the table with blank attributes | [profile.csv](assets/profile.csv)

### Import Data to MySQL
1. Copy fundamental and profile data into MySQL Docker Container
  ```bash
  docker cp ./doc/assets/fundamental.csv mysql:/root
  docker cp ./doc/assets/profile.csv mysql:/root
  ```
2. Launch into MySQL docker container
  ```bash
  docker exec -it compose_master0.dev_1 bash
  ```
3. Launch MySQL
  ```bash
  mysql --local-infile=1 -u root -PPASSWORD mysql
  ```
4. Reset MySQL Local Infile Permission
  ```bash
  SET GLOBAL local_infile = 1;
  ```
5. Import data with the following SQL
   Fundamental Data
  ```SQL
  LOAD DATA LOCAL INFILE "/root/fundamental.csv"
  INTO TABLE fundamental
  COLUMNS TERMINATED BY ','
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES;
  ```
  Profile Data
  ```SQL
  LOAD DATA LOCAL INFILE "/root/profile.csv"
  INTO TABLE profile
  COLUMNS TERMINATED BY ','
  LINES TERMINATED BY '\n'
  IGNORE 1 LINES;
  ```
6. Make index primary key in RDBMS

### Import Data to Hive by using Sqoop
1. Launch master node
  ```bash
  docker exec -it compose_master0.dev_1 bash
  ```
2. Run the following Sqoop Command
  Fundamental Data
  ```bash
  sqoop import --connect
  jdbc:mysql://172.20.0.5:3306/mysql?characterEncoding=utf8 --username root
  --password PASSWORD --table fundamental --hive-import
  ```
  Profile Data
  ```bash
  sqoop import --connect
  jdbc:mysql://172.20.0.5:3306/mysql?characterEncoding=utf8 --username root
  --password PASSWORD --table profile --hive-import
  ```

3. Create View for Fundamental Analysis
  ```SQL
  CREATE VIEW FUND_VIEW_1 as
  SELECT TICKER, YEAR, QUARTER, QUARTER_END, REVENUE, EARNING, EPS, PE_RATIO,
  DE_RATIO, CURRENT_RATIO, PROFIT_MARGIN, PNTA_RATIO, ROW_NUMBER()
  OVER(PARTITION BY TICKER ORDER BY QUARTER_END DESC) as CUM_QUARTER
  ```
### Build Kylin Cube
Log in to Kylin Portal and start building cube with the following schema

| Dimension                                                                         | Measure           |
|-----------------------------------------------------------------------------------|-------------------|
| TIME : year, ticker, quarter_end, quarter, cum_quarter                            | sum of all ratios |
| LOCATION : location                                                               |                   |
| COMPANY : ticker, sector, industry                                                |                   |
| RATIOS : pe_ratio, de_ratio, current_ratio, cash_ratio, profit_margin, pnta_ratio |                   |

### Prepareing SQL for the following Query
1. Profit for past 5 years all positive
```SQL
WITH A AS
(SELECT TICKER, QUARTER_END, EARNING, CUM_QUARTER
FROM FUND_VIEW_1
WHERE CUM_QUARTER < 6)
SELECT TICKER, EARNING AS PQ1, LAG(EARNING, 1) AS PQ2, LAG(EARNING, 2) AS PQ3,
LAG(EARNING, 3) AS PQ4, LAG(EARNING, 4) AS PQ5 FROM A WHERE CUM_QUARTER = 1
```
2. Profit Margin > 0.05
```SQL
SELECT TICKER, QUARTER_END, PROFIT_MARGIN
FROM FUND_VIEW_1
WHERE PROFIT_MARGIN > 0.05
AND CUM_QUARTER = 1
```
3. Current Ratio > 1
```SQL
SELECT TICKER, QUARTER_END, CURRENT_RATIO
FROM FUND_VIEW_1
WHERE CURRENT_RATIO > 1
AND CUM_QUARTER = 1
```
4. Debt to Equity Ratio < 2
```SQL
SELECT TICKER, QUARTER_END, DE_RATIO
FROM FUND_VIEW_1
WHERE DE_RATIO < 2
AND CUM_QUARTER = 1
```
5. P/E ratio < 10
```SQL
SELECT TICKER, QUARTER_END, PE_RATIO
FROM FUND_VIEW_1
WHERE PE_RATIO < 10
AND CUM_QUARTER = 1
```
6. Continuous Growth of P/E for last 2 quarter
```SQL
SELECT TICKER, PE_RATIO, LAG(PE_RATIO, 1) AS PE_RATIO_PQ
FROM FUND_VIEW_1
WHERE CUM_QUARTER = 1
```
