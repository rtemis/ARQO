import sys


def avg(suma, div):
    print (float(suma)/float(div))

def sum(n1, n2):
    print (float(n1)+float(n2))

def main(argv):

    # if sys.argv[1] == None or sys.argv[2] == None or sys.argv[3] == None:
    #     return -1

    if "--add" in argv:
        sum(argv[1], argv[2])
        exit(0)

    elif "--avg" in sys.argv:
        avg(argv[1], argv[2])
        exit(0)

    else:
        print ("ERROR")


if __name__== "__main__" :
    main(sys.argv[1:])

