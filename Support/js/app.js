let textMateHandleString = 'x-txmt-filehandle://job/Preview/';
let fileHandleString = 'file:///Applications/TextMate.app/Contents/Resources/';

let loaded_images_count = 0;

function scroll_window_please(){
    let css_params = {
        scrollTop: $("*:contains('REPLACEMEMEFORANCHOROPZ')").last().offset().top,
    };

    $("html, body").animate(css_params, 100, function(){
        document.body.innerHTML = document.body.innerHTML.replace(/REPLACEMEMEFORANCHOROPZ/g, '');
        $(".github-gfm").css('visibility', 'visible');
    });
}

$(document).ready(function() {
    if($("img").length > 0){
        $("img").one("load", function() {
            loaded_images_count += 1;
            if (loaded_images_count == $("img").length) {
                scroll_window_please();
            }
        }).each(function() {
            if(this.src.indexOf(textMateHandleString) > -1){
                this.src = localFilePath + this.src.replace(textMateHandleString, '');
            }
            if(this.src.indexOf(fileHandleString) > -1){
                this.src = localFilePath + this.src.replace(fileHandleString, '');
            }
            if(this.complete){
                $(this).load();
            }
        });
    } else {
        scroll_window_please();
    }
    
});
