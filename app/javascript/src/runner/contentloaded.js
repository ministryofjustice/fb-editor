/*! contentloaded.min.js - https://github.com/dperini/ContentLoaded - Author: Diego Perini - License: MIT */
function contentLoaded(b,i){var j=false,k=true,a=b.document,l=a.documentElement,f=a.addEventListener,h=f?'addEventListener':'attachEvent',n=f?'removeEventListener':'detachEvent',g=f?'':'on',c=function(d){if(d.type=='readystatechange'&&a.readyState!='complete')return;(d.type=='load'?b:a)[n](g+d.type,c,false);if(!j&&(j=true))i.call(b,d.type||d)},m=function(){try{l.doScroll('left')}catch(e){setTimeout(m,50);return}c('poll')};if(a.readyState=='complete')i.call(b,'lazy');else{if(!f&&l.doScroll){try{k=!b.frameElement}catch(e){}if(k)m()}a[h](g+'DOMContentLoaded',c,false);a[h](g+'readystatechange',c,false);b[h](g+'load',c,false)}}


// fb-runner addition
window.contentLoaded = contentLoaded;
