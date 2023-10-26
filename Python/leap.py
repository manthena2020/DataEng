while True:
    x =int(input(" please enter the year or enter 0 to exit   : "))
    if x ==0:
        print("program exit...close the window ")
        break
##    if x % 4 == 0:
##        if x % 100 == 0:
##            if x % 400 == 0:
##                print("leap year")
##            else:
##                print("not leap")
##    else:
##        print("Leap year.")
##    else:
##     print("not leap year")
    if ( x % 4 == 0 and x % 100 != 0) or x % 400 == 0:
         print("leap year")
    else:
       print("not leap year")
         
