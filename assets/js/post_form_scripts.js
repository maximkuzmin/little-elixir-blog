import SimpleMDE from "simplemde";

const inputSelector = "#post_form #markdown_input";
const placeholder = "Write something, you can do it!"

const simpleMdeConfig = {
  indentWithTabs: false,
  spellChecker: false,
  placeholder: placeholder,
};

function bindMarkdownEditorToForm() {
  const postMarkdownInput = document.querySelector(inputSelector);
  if (postMarkdownInput == null) { return };
  new SimpleMDE({ element: postMarkdownInput, ...simpleMdeConfig });
}

window.addEventListener("DOMContentLoaded", bindMarkdownEditorToForm)