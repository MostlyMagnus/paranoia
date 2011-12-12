/*
 * Define Page namespace
 */
if(typeof Page === "undefined") {
	Page = new Object();
}

/*
 * Capture Events
 */
Page.CaptureEvents = function() {
	$('a.map').live('click', function(){
		Page.PopulateMap($(this).attr('href'));
		return false;
	});
};


/*
 * Populate map
 */

 Page.PopulateMap = function(url) {
	var gridSize = 130;
	$.get( url, function(data) {
		if(data.name){
			$("#mapContainer").empty();
			$.each(data.map, function(x,column) {
				$.each(column, function(y, grid) {
					var classes = "grid";
					if(x==0) {
						classes += " break";
					}
					classes += " rt_" + grid.room_type;
					
					var node = "";
					if(grid.node) {
						node = grid.node.node_type;
					}
					$("#mapContainer").append('<div style="left:'+x*gridSize+'px;top:'+y*gridSize+'px;" class="'+classes+'">'+node+'</div>');
				});
			});

			/*$("#mapContainer").empty();
			for(y=0;y<data.height;y++) {
				for(x=0;x<data.width;x++) {
					if(data.map[x][y]){
						var classes = "grid";
						if(x==0) {
							classes += " break";
						}
						classes += " rt_" + data.map[x][y].room_type;
						$("#mapContainer").append('<div style="left:'+x*gridSize+'px;top:'+y*gridSize+'px;" class="'+classes+'"></div>');
					}
					
				}
			}
			*/
		}else{
			alert('Failed to load map');
		}
	}, "json");
 }

/*
 * Document ready event
 */
$(document).ready(function() {
	Page.CaptureEvents();
});
