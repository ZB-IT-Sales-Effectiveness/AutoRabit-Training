(function($){var defaults={direction:'top',theme:'',position:{}};var settings;var margins={border:6,top:15,right:15,bottom:15,left:15}
var themes=['','pastelblue','lightgray','darkgray'];var positions=['top','top-right','right-top','right','right-bottom','bottom-right','bottom','bottom-left','left-bottom','left','left-top','top-left'];var titles=[];function getThemeName(element){for(var n=0;n<themes.length;n++){if(element.hasClass(themes[n]))return themes[n]};return settings.theme;}
function getTooltipPosition(element){for(var n=0;n<positions.length;n++){if(element.hasClass(positions[n]))return positions[n];};return settings.direction;}
function getTooltipTag(_event){var title_=titles[_event.data.index];if(title_.length>0)return('<div id="simple-tooltip-'+_event.data.index+'" class="simple-tooltip '+getTooltipPosition($(_event.target))+' '+getThemeName($(_event.target))+'">'+title_+'<span class="arrow"> </span></div>');return false;}
function mouseOver(_event){var element=$(this);var tooltip_tag=getTooltipTag(_event);if(tooltip_tag){var exist_=$('body').find('#simple-tooltip-'+_event.data.index);if(exist_.length>0){_event.preventDefault();return false;}
var temp_=$(tooltip_tag).appendTo($('body'));temp_.hide();reposTooltip(temp_,element);temp_.delay(180).fadeIn(200);}
_event.preventDefault();};function mouseOut(_event){var exist_=$('body').find('#simple-tooltip-'+_event.data.index);if(exist_.length==0){_debug('no existe el elemento: cancela');_event.preventDefault();return false;}
if(exist_.css('opacity')==0){_debug('opacidad 0: eliminarrrrrr');_event.preventDefault();exist_.remove();return false;}
exist_.clearQueue().stop().fadeOut(100,function(){exist_.remove()});};function reposTooltip(tooltip,element){var pos=element.offset();switch(getTooltipPosition(element)){default:case'top':pos.top-=parseInt(tooltip.outerHeight()+margins.top);pos.left+=parseInt((element.outerWidth()-tooltip.outerWidth())/2);break;case'top-right':pos.top-=parseInt(tooltip.outerHeight()+margins.bottom);pos.left+=parseInt(element.outerWidth()-margins.right-margins.border);break;case'right-top':pos.top-=parseInt(tooltip.outerHeight()-margins.bottom);pos.left+=parseInt(element.outerWidth()+margins.right);break;case'right':pos.top+=parseInt((element.outerHeight()-tooltip.outerHeight())/2);pos.left+=parseInt(element.outerWidth()+margins.right);break;case'right-bottom':pos.top+=parseInt(element.outerHeight()-margins.bottom);pos.left+=parseInt(element.outerWidth()+margins.right);break;case'bottom-right':pos.top+=parseInt(element.outerHeight()+margins.bottom);pos.left+=parseInt(element.outerWidth()-margins.right-margins.border);break;case'bottom':pos.top+=parseInt(element.outerHeight()+margins.bottom);pos.left+=parseInt((element.outerWidth()-tooltip.outerWidth())/2);break;case'bottom-left':pos.top+=parseInt(element.outerHeight()+margins.bottom);pos.left-=parseInt(tooltip.outerWidth()-margins.left-margins.border);break;case'left-bottom':pos.top+=parseInt(element.outerHeight()-margins.bottom);pos.left-=parseInt(tooltip.outerWidth()+margins.left);break;case'left':pos.top+=parseInt((element.outerHeight()-tooltip.outerHeight())/2);pos.left-=parseInt(tooltip.outerWidth()+margins.left);break;case'left-top':pos.top-=(tooltip.outerHeight()-margins.bottom);pos.left-=parseInt(tooltip.outerWidth()+margins.left);break;case'top-left':pos.top-=(tooltip.outerHeight()+margins.bottom);pos.left-=parseInt(tooltip.outerWidth()-margins.left);break;}
tooltip.css('top',pos.top);tooltip.css('left',pos.left);}
function addActions(){$('.simpletooltip').each(function(index,value){$(value).css('cursor','pointer');titles[index]=$(value).attr('title');$(value).attr('title','');$(value).bind('mouseenter',{index:index},mouseOver);$(value).bind('mouseleave',{index:index},mouseOut);})};function setSettings(settings_){settings=$.extend(defaults,settings_);};$.simpletooltip=function(settings_){setSettings(settings_);addActions();};})(jQuery);
