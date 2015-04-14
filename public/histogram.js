
ChurnCharts.histogram = function(data) {

	var CHEIGHT = 600;
	var BWIDTH = 3;
	var BGAP = 1;
	var LEFTSPACE = 40;

	data.sort(function(da, db) { return db.count - da.count } )

	d3.selectAll("svg").remove();
	var chart = d3.select("#chart-wrapper").append("svg")
		.attr("class", "chart")
		.attr("width", (BWIDTH + BGAP) * data.length + LEFTSPACE)
		.attr("height", CHEIGHT + 5); /* to accomodate bottom label */
		
	var xscale = d3.scale.linear()
		.domain([0, data.length])
		.rangeRound([LEFTSPACE, (BWIDTH + BGAP) * data.length + LEFTSPACE])
		
	var yscale = d3.scale.linear()
		.domain([0, d3.max(data, function(d) { return d.count })])
		.rangeRound([CHEIGHT-1, 1]);

	var fscale = d3.scale.linear()
		.domain([0, d3.max(data, function(d) { return d.churn })])
		.range(["#46F", "#F64"]);

	var yaxis = d3.svg.axis()
		.scale(yscale)
		.orient("left")
		.ticks(10);
		
	chart.selectAll("line")
		.data(yscale.ticks(10))
		.enter().append("line")
		.attr("x1", function(td) { return xscale(0) })
		.attr("x2", function(td) { return xscale(data.length) })
		.attr("y1", yscale)
		.attr("y2", yscale)
		.style("stroke", "#ccc");

	chart.selectAll("rect")
		.data(data)
		.enter().append("rect")
		.attr("x", function(d, i) { return xscale(i) })
		.attr("y", function(d) { return yscale(d.count) })
		.attr("height", function(d) { return CHEIGHT -yscale(d.count) })
		.attr("width", BWIDTH)
		.attr("shape-rendering", "crispEdges")
		.style("fill", function(d) { return fscale(d.churn) })
		.call(ChurnCharts.tooltip());
				
	chart.append("g")
		.attr("class", "axis")
		.attr("transform", "translate(" + LEFTSPACE + ", 0)")
		.call(yaxis);
}

