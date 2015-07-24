$(document).on("ready page:load",function() {
	var path = $(location).attr('pathname');
	var dashboard = path.split('/')[1] == 'admin';	
	var page = path.split('/')[2];
	var elem = '.'+page;
	if (dashboard){
		$('select').foundationSelect();
		$(document).foundation();
		$('.dashboard li').removeClass('active');
		$(elem).addClass('active');
		if ($(elem).parents('.has-dropdown').length) {
			$(elem).parents('.has-dropdown').addClass('active');
		}
	}
	$(".remote .new_legacy_legacy_site").on("submit",function(e){
  		e.preventDefault();
  		
  		$('.error').remove();
  		var errorList = getErrors();
  		if (errorList.length == 0){
	  		debugger;
	  		$.ajax({
			  	type: "POST",
			  	url: this.action,
			  	data: $( this ).serialize(),
			  	success: function(data){
				  		
				  		var html = "<div data-alert class='alert-box'>"+data+"<a href='#' class='close'>&times;</a></div>"
				  	 	$('form').prepend(html);
				  	 	$('.close').click(function(){
				  	 	$('.alert-box').remove();
			  		});
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
   });
	
   var getErrors = function(){
		var list = [];
		$.each($("form input.required"),function(i,v){
			if (v.value == ''){
				list.push(v)
			}
		});
		return list;
	}
  
  

});