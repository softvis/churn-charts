# Churn Charts

Visualisations to analyse code churn based on Git logs



## Timeline

![Churn timeline image](docs/example-timeline.png)  
    
The chart has a row per file, showing the code churn on a daily basis. Churn in this context is simply the number of lines of code added and deleted. Bars are only shown for days on which the file was changed.

The more lines of code added and/or deleted the higher the bar for that day. The colour of the bar changes from blue to red based on how much churn there was relative to the estimated file size. The lowest value is 1, which means that all lines were just added and then never touched again. There is (obviously) no upper limit but in the chart the 'reddest' colour is shown when the aggregated churn is at least 10 times as big as the estimated size of the file, ie. when each line of the file has been touched (on average) ten times.

More information is available by hovering over the idividual boxes. The filename shown is the name of the file on that day. It can change over time when the file gets renamed.



## Running the visualisations

Create the Git log as follows and copy the `gitlog.txt` file into the root directory of this app. The file is in `.gitignore` already.

    git log --reverse --all -M -C --numstat --format="--%ct--%cI--%cn%n" > gitlog.txt
    

Then run the `app.rb` script

    ./app.rb
    
or, using the rerun gem:

    rerun 'ruby app.rb' 

Connect to the webserver, which is usually running on [http://localhost:4567](http://localhost:4567)










    
    