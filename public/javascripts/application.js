$(function(){
    $('#toc').toc()
});

$.extend($.fn,{
    toc: function(){
        toc = $(this);
        $("h2,h3,h4,h5,h6").each(function(){
            var indent = $(this).get()[0].localName.replace("h", "");
            var target = $(this);
            li = $("<li style='text-indent:"+(indent-2)+"em;'></li>");
            li.html($('<a>'+$(this).text()+'</a>').click(function(){
                $('html,body').animate({scrollTop: target.offset().top - 40},400);
            }));
            li.appendTo($(toc));
        });
    }
});
