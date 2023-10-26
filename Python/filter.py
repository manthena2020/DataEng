import pandas as pd
df = pd.read_csv("C:\data\email.txt",names=["Sno","Name","MailId","MobileNo"])
print('')
print('')
print('')
print(df)
#filtered = df[~df['MailId'].str.contains('@')]
#filtered1 = df[df['MobileNo'].astype(str).str.strip().str.len() < 10]
def fun1(m):
    if '@' in m:
        return True
    else:
        return False
filtered = df[~df['MailId'].apply(fun1)]

def fun2(mo):
    if len(str(mo))<10:
        return True
    else:
        return False
filtered1 = df[df['MobileNo'].apply(fun2)]

print('')
print('')
print('')
print("----------------- DATA MISSING @ --------------")
print('')
print('')
print('')
print(filtered)
print('')
print('')
print('')
print("----------------- DATA MISSING mobile no --------------")
print(filtered1)
