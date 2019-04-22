#!/usr/local/bin/python3.7

# Open File
with open('./fundamental.csv','r') as f:
    i = 0
    c = 0
    previous_year = ''
    for line in f:
        word = line.split(',')
        current_year = word[2]
        if word[2] == 'year':
            continue
        elif current_year == previous_year:
            i += 1
            # c += 1
        else:
            previous_year = current_year
            i = 1
            # c += 1
        with open('new.csv','a') as fout:
            # line = line.strip('\n') + ',' + str(i) + ',' + str(c)+'\n'
            line = line.strip('\n') + str(i)+'\n'
            print(line)
            fout.write(line)
