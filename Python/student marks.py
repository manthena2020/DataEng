x = input("Input a list of student scores ").split()
#for n in range(0, len(student_scores)):
 # student_scores[n] = int(student_scores[n])
x = list(map(int, x))
print(x)
# 🚨 Don't change the code above 👆

#Write your code below this row 👇
hs = 0
for s in x:
   if s > hs:
      hs = s
print(f"The highest score in the class is: {hs}") 
