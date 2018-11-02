let textMateHandleString = 'x-txmt-filehandle://job/Preview/';
let fileHandleString = 'file:///Applications/TextMate.app/Contents/Resources/';

let loaded_images_count = 0;

function scroll_window_please(){
    let zoom_factor = Number($('.github-gfm').css('zoom'));
    let last_elements_offset = $("*:contains('REPLACEMEMEFORANCHOROPZ')").last().offset().top;

    let css_params = {
        scrollTop: last_elements_offset * zoom_factor,
    };

    $("html, body").animate(css_params, 100, function(){
        document.body.innerHTML = document.body.innerHTML.replace(/REPLACEMEMEFORANCHOROPZ/g, '');
        $(".github-gfm").css('visibility', 'visible');
    });
}

$(document).ready(function() {
    if($("img").length > 0){
        $("img").each(function() {
            if(this.src.indexOf(textMateHandleString) > -1){
                this.src = localFilePath + this.src.replace(textMateHandleString, '');
            }
            if(this.src.indexOf(fileHandleString) > -1){
                this.src = localFilePath + this.src.replace(fileHandleString, '');
            }
        });
    }
    scroll_window_please();
});

