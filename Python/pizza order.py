print("________________________________________________________________________")
print("                                   Our menu                          ")
print("________________________________________________________________________")
print("Small pizza                             :       $15")
print("Medium pizza                            :       $20")
print("Large pizza                             :       $25")
print("Pepperoni for small pizza               :       +$2")
print("Pepperoni for medium/Large  pizza       :       +$3")
print("Extra cheese for any size pizza         :       +$1")
print("________________________________________________________________________")
print("")

print("_______________________________Please order the items_____________________")

while True:
    x = input("Hello, welcome to Pizza Hut! Which pizza size would you like to order (s/m/l), or enter 0 to exit? ")
    if x == '0':
        print("We are closing now. Thank you for visiting Pizza Hut!")
        break
    else:
        p = input("Would you like to add pepperoni? (y/n): ")
        c = input("Would you like to add extra cheese? (y/n): ")

        cost = 0
        if x == 's':
            cost = 15
            if p == 'y':
                cost += 2
            if c == 'y':
                cost += 1
        elif x == 'm':
            cost = 20
            if p == 'y':
                cost += 3
            if c == 'y':
                cost += 1
        elif x == 'l':
            cost = 25
            if p == 'y':
                cost += 3
            if c == 'y':
                cost += 1

        print("Your total cost is:", cost)
