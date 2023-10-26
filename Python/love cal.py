# 🚨 Don't change the code below 👇
print("Welcome to the Love Calculator!")
name1 = input("What is your name? \n")
name2 = input("What is their name? \n")
# 🚨 Don't change the code above 👆

#Write your code below this line 👇
x = name1 + name2
l = x.lower()
t = l.count("t")
r = l.count("r")
u = l.count("u")
e = l.count("e")
true = t+r+u+e
p = l.count("l")
o = l.count("o")
v = l.count("v")
e = l.count("e")
love = p+o+v+e
z = str(true)+str(love)

print(f"Your score is {z}.")
