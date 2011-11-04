$(document).ready(function() {
    $(".favorite > a > img")
        .hover(function() { 
            var src = $(this).attr("src");
            var array = src.split("/");
            array[array.length-1] = $(this).data('next');
            $(this).attr("src", array.join("/"));
        },
        function() {
            var src = $(this).attr("src");
            var array = src.split("/");
            array[array.length-1] = $(this).data('initial');
            $(this).attr("src", array.join("/"));
        });
});
