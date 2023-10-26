print("WELCOME TO BMI CALCULATOR")

x = float(input("PLEASE ENTER YOUR WEIGHT\n"))
y = float(input("PLEASE ENTER YOUR HEIGHT\n"))

y = y ** 2
z = round((x / y),2)




if z < 18.5:
    print(f"your BMI is {z}, you are underweight")
elif z <25:
    print(f"your BMI is {z}, you are  normal weight")
elif z <30:
    print(f"your BMI is {z}, you are  slightly overweight")
elif z <35:
    print(f"your BMI is {z}, you are  obese")
else:
    print(f"your BMI is {z}, you are clinically obese")
    
    

