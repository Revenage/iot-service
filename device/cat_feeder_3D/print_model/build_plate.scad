module build_plate(bp,manX,manY){

		translate([0,0,-.52]){
			if(bp == 0){
				%cube([285,153,1],center = true);
			}
			if(bp == 1){
				%cube([225,145,1],center = true);
			}
			if(bp == 2){
				%cube([120,120,1],center = true);
			}
			if(bp == 3){
				%cube([manX,manY,1],center = true);
			}
		
		}
		translate([0,0,-.5]){
			if(bp == 0){
				for(i = [-14:14]){
					translate([i*10,0,0])
					%cube([.5,153,1.01],center = true);
				}
				for(i = [-7:7]){
					translate([0,i*10,0])
					%cube([285,.5,1.01],center = true);
				}	
			}
			if(bp == 1){
				for(i = [-11:11]){
					translate([i*10,0,0])
						%cube([.5,145,1.01],center = true);
				}
				for(i = [-7:7]){
					translate([0,i*10,0])
						%cube([225,.5,1.01],center = true);
				}
			}
			if(bp == 2){
				for(i = [-6:6]){
					translate([i*10,0,0])
						%cube([.5,120,1.01],center = true);
				}
				for(i = [-6:6]){
					translate([0,i*10,0])
						%cube([120,.5,1.01],center = true);
				}
			}
			if(bp == 3){
				for(i = [-(floor(manX/20)):floor(manX/20)]){
					translate([i*10,0,0])
						%cube([.5,manY,1.01],center = true);
				}
				for(i = [-(floor(manY/20)):floor(manY/20)]){
					translate([0,i*10,0])
						%cube([manX,.5,1.01],center = true);
				}
			}
		}
}