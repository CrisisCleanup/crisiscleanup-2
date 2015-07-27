$(document).ready(function(){
	$(".remote .new_legacy_legacy_site input[type='submit']").on("click",function(e){
		e.preventDefault();
		$('.error').remove();
		var errorList = getErrors();
		if (errorList.length == 0){
  		$.ajax({
		  	type: "POST",
		  	url: this.action,
		  	data: $( this ).serialize(),
		  	success: function(data){
			  		debugger;
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

})
