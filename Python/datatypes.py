x = input(" ENTER NUMBER  :   ")

x = list(map(int,x))


#print(type(x))


print(" THE VALUE ENTERED IS :", x)
#y =0
#y = int(x[0])+int(x[1])

#print(y)

le = len(x)

y = 0

for i in range(0,le):

    y += x[i]

    



print(y)
