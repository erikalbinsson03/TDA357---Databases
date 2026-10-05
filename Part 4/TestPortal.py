import PortalConnection

def pause():
  input("Press Enter to continue...")
  print("")

if __name__ == "__main__":        
    c = PortalConnection.PortalConnection()
    
    print("Test1:")
    #print(c.getInfo("2222222222"))
    pause()

    print("Test2:")
    #print(c.register("2222222222", "CCC333"))
    #print(c.getInfo("2222222222"))
    pause()

    print("Test3:")
    #print(c.register("2222222222", "CCC333"))
    pause()
    
    print("Test 4:")
    #print(c.unregister("2222222222", "CCC333"))
    #print(c.getInfo("2222222222"))
    #print(c.unregister("2222222222", "CCC333"))
    pause()

    print("Test 5:")
    #print(c.register("2222222222", "CCC444"))
    pause()

    print("Test 6:") # requires student 2 is registered amd that course is full and two people in queue already
    #print(c.getInfo("2222222222"))
    #print(c.unregister("2222222222", "CCC333"))
    #print(c.register("2222222222", "CCC333"))
    #print(c.getInfo("2222222222"))
    pause()

    print("Test 7:")
    #print(c.getInfo("2222222222"))
    #print(c.unregister("2222222222", "CCC333"))
    #print(c.register("2222222222", "CCC333"))
    #print(c.getInfo("2222222222"))
    pause()

    print("Test 8:") # requires overfull course where student 2 is last in waitinglist
    #print(c.getInfo("2222222222"))
    #print(c.unregister("6666666666", "CCC333"))
    #print(c.getInfo("2222222222"))
    pause()

    print("Test 9:")
    #print(c.unregister("2222222222","x' OR 'a'='a"))
    pause()



