# 01a62bb0

<h1 align="center">Milan pollution Shiny App </h1>
<p> The aim of this project is the analysis of the data taken from the site of the Comune di Milano using CKAN Data Application programming interface(API). </p>
<br>
<h2> Installation</h2>

```R
# first install the R package "devtools" (.... OTHERS TO BE SPECIFIED) if not installed
devtools::install_github('unimi-dse/01a62bb0')
```

<br>
<h2> Usage</h2>
<p> Load the package. </p>

```R
require(milanpollution)
```

<p> There are two main functions of the package that are <code> pollution()</code> and <code> installpack()</code>. </p>
  
 <h3> Functions </h3>
 <code> installpack()</code>
 <p>This function will install the needed packages to run the application. <bold> It is suggested </bold> to run this function before the <italic> pollution() </italic> function. </p>

<br>
 <code> pollution()</code>
  <p> This function loads the Shiny  application. </p>
  
  <br>
 <h2> Description of the application </h2>
<p> When runned the pollution() function in the console, will be charged the application. It takes a bit to get and charge the data from the OpenData Comune di Milano site using CKAN API. Charged the dataset, the application will starts. </p>

<h3> Main page: Pollution </h3>
#--- put IMAGE ---
<p> In the main page are presented two plots: the time series of the datas and the related forecast. 
  <li> The first plot represents the time series of the data deteceted by every station day by day. It is possible to check the Checkbox to enable the visualization of the linear regression line. </li>
  <li> The second plot represents the forecast of the time series. It is possible to set a different lag for the forecast using the slidebar. </li>
  <p> Then is possible to select the year of the dataset in interest using a selector </p>
</p>

<h3> Second page: Stations </h3>
#--- put IMAGE ---
<p> In this page is possible to see the barplot representing the detected data from each station in the selected year. </p>

<h3> Third page: About </h3>
<p> This section describes the aim of the project. </p>
