let textMateHandleString = 'x-txmt-filehandle://job/Preview/';
let fileHandleString = 'file:///Applications/TextMate.app/Contents/Resources/';

let required_images_count = 0;
let loaded_images_count = 0;

function scroll_window_please(){
    let css_params = {
        scrollTop: $("*:contains('REPLACEMEMEFORANCHOROPZ')").last().offset().top,
    };
    // console.dir(css_params);

    $("html, body").animate(css_params, 100, function(){
        document.body.innerHTML = document.body.innerHTML.replace(/REPLACEMEMEFORANCHOROPZ/g, '');
        $(".github-gfm").css('visibility', 'visible');
    });
}

$(document).ready(function() {
    required_images_count = document.images.length;
    
    if(required_images_count > 0){
        Array.prototype.forEach.call(document.images, function(image){
            if(image.src.indexOf(textMateHandleString) > -1){
                image.src = localFilePath + image.src.replace(textMateHandleString, '');
            }
            if(image.src.indexOf(fileHandleString) > -1){
                image.src = localFilePath + image.src.replace(fileHandleString, '');
            }
            image.onload = function(){
                loaded_images_count += 1;
                // console.log('loaded_images_count', loaded_images_count);
                if(required_images_count == loaded_images_count){
                    scroll_window_please();
                }
            }
        });
    } else {
        scroll_window_please();
    }
});
