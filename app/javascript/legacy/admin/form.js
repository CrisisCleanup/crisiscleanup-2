$(document).on("ready page:load",function() {
	$('.preview').on('click', function(event){
				var html = $.parseHTML($('#form_html').val());
				$('#preview .lead').empty();

				$('#preview .lead').append( html );
	})	
});