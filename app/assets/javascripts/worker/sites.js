$(document).ready(function(){
	$(".remote .new_legacy_legacy_site, .edit_legacy_legacy_site").on("submit",function(e){ 
	
		e.preventDefault();
		e.stopImmediatePropagation();
		$('.error, .alert-box').remove();
		var errorList = getErrors();
		if (errorList.length == 0){
	  		$.ajax({
			  	type: "POST",
			  	url: this.action,
			  	data: $( this ).serialize(),
			  	success: function(data){
				  		
				  		if (data["id"] == undefined && data["updated"] == undefined){
					  		var html = "<div data-alert class='alert-box'>"+data+"<a href='#' class='close'>&times;</a></div>"
					  	 	$('form').prepend(html);
					  	 	$('.close').click(function(){
					  	 		$('.alert-box').remove();
					  	 	});
					  	
					  	} else if(data["updated"] != undefined) {

					  		var html = "<div data-alert class='alert-box'>"+data["updated"]["name"]+" was successfully saved<a href='#' class='close'>&times;</a></div>";
					  	 	$('form').prepend(html);
					  	 	$('.close').click(function(){
					  	 		$('.alert-box').remove();
					  	 	});
					  		new CCMAP('map-canvas',data["updated"]["legacy_event_id"],data["updated"]["latitude"],data["updated"]["longitude"],18).build(data["updated"]["id"]);
					  	} else {		
					  		var html = "<div data-alert class='alert-box'>"+data['name']+" was successfully saved<a href='#' class='close'>&times;</a></div>";
					  	 	$('form').prepend(html);
					  	 	$('.close').click(function(){
					  	 		$('.alert-box').remove();
					  	 	});
					  	 	
							$('html,body').animate({scrollTop: 0});
					  		$('form')[0].reset();

							new CCMAP('map-canvas',data["legacy_event_id"],data["latitude"],data["longitude"],18).build(data["id"]);
					  	}

			  		},
		  		error: function(){
		  			alert('500 error');
		 		}
			});  	
		}else{
			$.each(errorList,function(i,v){			
				$(v).parent().append("<small class='error'>can't be blank</small>") 
			})
		}
		return false;
	});
	
	var getErrors = function(){
		var list = [];
		$.each($("form input.required"),function(i,v){
			if (v.value == ''){list.push(v)}
		});
		return list;
	}

})
