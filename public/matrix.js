
ChurnCharts.matrix = function(data, size, spacing) {

  var numFiles = d3.max(data, function(d) { return d.index0 > d.index1 ? d.index0 : d.index1 });

  var BSIZE = size;
	var CHEIGHT = spacing * numFiles;
	var CWIDTH = spacing * numFiles;

	d3.selectAll("svg").remove();
	var chart = d3.select("#chart-wrapper").append("svg")
		.attr("class", "chart")
		.attr("width", CWIDTH)
		.attr("height", CHEIGHT);
		
	var xscale = d3.scale.linear()
		.domain([0, d3.max(data, function(d) { return d.index0 })])
		.rangeRound([0, CWIDTH - BSIZE])
		
	var yscale = d3.scale.linear()
		.domain([0, d3.max(data, function(d) { return d.index1 })])
		.rangeRound([0, CHEIGHT - BSIZE])

	var fscale = d3.scale.log()
		.domain([1, d3.max(data, function(d) { return d.weight })])
		.range(["#BDF", "#248"]);
		
	chart.selectAll("rect")
		.data(data)
		.enter().append("rect")
		.attr("x", function(d) { return xscale(d.index0) })
		.attr("y", function(d) { return yscale(d.index1) })
		.attr("width", function(d) { return BSIZE })
		.attr("height", function(d) { return BSIZE })
		.attr("shape-rendering", "crispEdges")
		.style("fill", function(d) { return fscale(d.weight) })
		.call(ChurnCharts.tooltip());
				
}

