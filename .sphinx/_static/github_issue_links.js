// if we already have an onload function, save that one
var prev_handler = window.onload;

window.onload = function() {
    // call the previous onload function
    if (prev_handler) {
        prev_handler();
    }

    const link = document.createElement("a");
    link.classList.add("muted-link");
    link.classList.add("github-issue-link");
    link.text = "Ask a question";
    link.href = (
        github_qa
        + "&title=%5BQuestion%5D%3A+ADD+YOUR+QUESTION+HERE"
        + "&body=*Please+describe+your+question+or+issue+with+Charmed+HPC*"
        + "%0A%0A%0A%0A%0A"
        + "---"
        + "%0A"
        + `*Redirected+from+document%3A+${location.href}*`
    );
    link.target = "_blank";

    const div = document.createElement("div");
    div.classList.add("github-issue-link-container");
    div.append(link)

    const container = document.querySelector(".article-container > .content-icon-container");
    container.prepend(div);
};
