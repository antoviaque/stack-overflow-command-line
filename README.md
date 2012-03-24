Stack Overflow - Command Line Tool
==================================

Allows to query Stack Overflow's questions & answers from the command line. It can either be used in "online" mode, where the StackOverflow API is queried, or offline, by downloading the latest dump released by StackOverflow.

Install
=======

    $ sudo gem install stackoverflow

If you plan on using the offline mode, download the data (be patient, several GB to get!):

    $ so --update

Use
===

    $ so git revert
                                                                                                       
       [1]     (+45)    GIT revert to previous commit... how?                                              
       [2]     (+30)    Git, Revert to a commit by SHA hash?                                               
       [3]     (+28)    How to revert a "git rm -r ."?                                           
       [4]     (+26)    Revert multiple git commits                                                        
       [5]     (+22)    Eclipse git checkout (aka, revert)                                                 
       [6]     (+9)     git revert changes to a file in a commit                                           
       [7]     (+8)     Revert a range of commits in git                                                   
       [8]     (+8)     Git revert last commit in heroku                                                   
       [9]     (+8)     Git revert local commit                                                            
       [10]    (+6)     Revert a Git Submodule pointer                                                     
       [11]    (+5)     Git revert merge to specific parent                                                
       [12]    (+5)     Git force revert to HEAD~7                                                         
       [13]    (+5)     Git merge, then revert, then revert the revert                                     
       [14]    (+4)     hg equivalant of git revert                                                        
       [15]    (+3)     git revert in Egit                                                                 
       [16]    (+3)     Revert back to a specific commit in git, build, then revert to the latest changes  
       [17]    (+3)     git revert back to certain commit                                                  
       [18]    (+2)     git how to revert to specific revision                                             
       [19]    (+2)     Git: Revert to previous commit status                                              
       [20]    (+2)     Git Revert, Checkout and Reset for Dummies                                         
       [21]    (+1)     Git cancel a revert                                                                
       [22]    (+1)     git revert and git checkout                                                        
       [23]    (0)      undo revert in git or tortoisegit                                                  
       [24]    (0)      How to apply a git revert?                                                         
       [25]    (0)      Git Revert Error Message?                                                          

    $ so git revert 2

        [...Shows the question & answers for #2: "Git, Revert to a commit by SHA hash?"...]

Offline mode:

    $ so --update
    $ so --offline git revert
    $ so --offline git revert 2

License
=======

* Data (c) [Stack Overflow][], [CC-BY-SA 3.0][]
* Code (c) [Xavier Antoviaque][], [AGPLv3][]

[Stack Overflow]:       http://stackoverflow.com/
[Xavier Antoviaque]:    http://antoviaque.org/
[CC-BY-SA 3.0]:         http://creativecommons.org/licenses/by-sa/3.0/
[AGPLv3]:               http://www.gnu.org/licenses/agpl-3.0.html

