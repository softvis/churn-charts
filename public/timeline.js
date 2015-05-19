
ChurnCharts.timeline = function(data, SPACING) {

  var dateMin = d3.min(data, function(d) { return new Date(d.date)});
  var dateMax = d3.max(data, function(d) { return new Date(d.date)});
  var numFiles = d3.max(data, function(d) { return d.findex });

  var BWIDTH = Math.min(SPACING * 2, 8)
  var MINWH = 3;
  var OVERSIZEH = 3;
  var PADDINGV = 4;
	
  var CWIDTH = ((dateMax - dateMin)/(24*60*60*1000) + 1) * (BWIDTH);
	var CHEIGHT = (numFiles + 2) * SPACING;

	d3.selectAll("svg").remove();
	var chart = d3.select("#chart-wrapper").append("svg")
		.attr("class", "chart")
		.attr("width", CWIDTH)
		.attr("height", CHEIGHT);
		
	var xscale = d3.scale.linear()
		.domain([dateMin, dateMax])
		.rangeRound([0, CWIDTH - BWIDTH])
		
	var yscale = d3.scale.linear()
		.domain([0, d3.max(data, function(d) { return d.findex })])
		.rangeRound([SPACING, CHEIGHT - SPACING]);
    
	var fscale = d3.scale.linear()
    .domain([0, 10])
		.range(["#46F", "#F64"]);
		
  var hscale = d3.scale.linear()
    .domain([0, d3.max(data, function(d) { return d.churn })])
		.rangeRound([MINWH, SPACING * OVERSIZEH]);

  if (SPACING > 2) {
    var yaxis = d3.svg.axis()
      .scale(yscale)
      .orient("left")
      .ticks(numFiles)
      .tickSize(-CWIDTH, 0, 0)
      .tickFormat("");  
    
    chart.append("g")         
      .attr("class", "grid")
      .call(yaxis);  
  }

	chart.selectAll("rect")
		.data(data)
		.enter().append("rect")
		.attr("x", function(d) { return xscale(new Date(d.date)) })
		.attr("y", function(d) { return yscale(d.findex) - hscale(d.churn) / 2})
		.attr("width", BWIDTH)
		.attr("height", function(d) { return hscale(d.churn) })
		.attr("shape-rendering", "crispEdges")
		.style("fill", function(d) { return fscale(d.churnA/d.size) })
    .call(ChurnCharts.tooltip());
		    		
}


