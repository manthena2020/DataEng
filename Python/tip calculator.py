print("WELCOME TO TIP CALCULATOR")

bill = float(input(" WHAT IS THE COST OF THE BILL ? : $"))

count = int(input(" TOTAL NO OF PERSONS TO SHARE THIS BILL ? :   "))

tip = bill*(12/100)

tbill = (bill + tip) / count

print("")
print("")
print("***********************WELCOME TO  SHARE CALCULATOR**********************")

print("")
print("")
print(f"TOTAL BILL                   :          {bill} ")
print("")
print(f"TOTAL PERSONS                :          {count}")
print("")
print(f"TIP                          :          {tip} ")
print("")
print("")
print(f"TOTAL PAYBLE                 :          {tbill}")
print("")
print("")
print("*************************************************************************")




