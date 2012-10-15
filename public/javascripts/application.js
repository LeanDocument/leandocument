$(function(){
    $('#toc').toc();
    var $window = $(window);
    $('.bs-docs-sidenav').affix({
      offset: {
        top: function () { return $window.width() <= 980 ? 90 : 80 }
      , bottom: 270
      }
    })
});

$.extend($.fn,{
    toc: function(){
        toc = $(this);
        $("h2,h3,h4,h5,h6").each(function(i){
            var indent = $(this).get()[0].localName.replace("h", "");
            var target = $(this);
            target.attr("id", "data-index-"+i);
            li = $("<li style='text-indent:"+((indent-2)/1.5)+"em;' data-index='"+i+"' data-indent='"+indent+"'></li>");
            li.html($('<span class="anchor">'+$(this).text()+'</span>').click(function(){
                $('html,body').animate({scrollTop: target.offset().top - 40},400);
            }).hover(function(){
                $(this).addClass("pointer");
            }, function(){
                $(this).removeClass("pointer");
            }));
            li.appendTo($(toc));
            if (indent > 2 && li.prev().attr("data-indent") != indent) {
                icon = $("<i class='icon-minus'></i>").click(function(){
                    open = $(this).hasClass("icon-plus")
                    if (open) {
                        $(this).addClass("icon-minus").removeClass("icon-plus");
                    }else{
                        $(this).addClass("icon-plus").removeClass("icon-minus");
                    }
                    parent = $(this).parent();
                    last = $(this).parent();
                    while (true && last.length > 0){
                        next = last.next();
                        if (parent.attr("data-indent") >= next.attr("data-indent")) {
                            break;
                        }
                        open ? next.slideDown() : next.slideUp();
                        last = next;
                    }
                });
                icon.prependTo(li.prev())
            }
        });
    }
});
