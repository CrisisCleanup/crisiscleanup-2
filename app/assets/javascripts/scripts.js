$(document).on("ready page:load",function() {
	var path = $(location).attr('pathname');
	var dashboard = path.split('/')[1] == 'admin';	
	var page = path.split('/')[2];
	var elem = '.'+page;
	if (dashboard){
		$('select').foundationSelect()
		$(document).foundation();
		$('.dashboard li').removeClass('active');
		$(elem).addClass('active');
		if ($(elem).parents('.has-dropdown').length) {
			$(elem).parents('.has-dropdown').addClass('active');
		}
	}
});


