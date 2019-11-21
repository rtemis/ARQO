import sys


def avg(suma, div):
    return (float(suma)/float(div))

def sum(n1, n2):
    return (float(n1)+float(n2))

def main():
    if sys.argv[1] == None or sys.argv[2] == None or sys.argv[3] == None:
        return -1

    if "--add" in sys.argv[1]:
        print(sum(sys.argv[2], sys.argv[3]))
        return 0

    elif "--avg" in sys.argv[1]:
        print(avg(sys.argv[2], sys.argv[3]))
        return 0
    
    else: 
        print ("ERROR")
    

if __name__== "__main__" :
    main()

