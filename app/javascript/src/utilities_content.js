const showdown  = require('showdown');
const converter = new showdown.Converter({
                    noHeaderId: true,
                    strikethrough: true,
                    omitExtraWLInCodeBlocks: true,
                    simplifiedAutoLink: false,
                    tables: true,
                    disableForced4SpacesIndentedSublists: true
                  });
const sanitizeHtml = require('sanitize-html');

showdown.setFlavor('github');

/* Convert HTML to Markdown by tapping into third-party code.
 * Includes clean up of HTML by stripping attributes and unwanted trailing spaces.
 **/
function convertToMarkdown(html) {
  var markdown = converter.makeMarkdown(html);
  return cleanInput(markdown);
}


/* Convert Markdown to HTML by tapping into third-party code.
 * Includes clean up of both Markdown and resulting HTML to fix noticed issues.
 **/
function convertToHtml(markdown) {
  var html = converter.makeHtml(markdown);
  return cleanInput(html);
}


/* Opportunity safely strip out anything that we don't want here.
 *
 * 1. Something in makeMarkdown is adding <!-- --> markup to the result
 *    so we're trying to get rid of it.
 *
 * 2. sanitize-html is altering automatic link syntax by removing
 *    everything in (including) angle brackets added by showdown.
 *
 *    e.g. [link text](<http://some.url/here>)
 *
 *         results in this incorrect markdown (and output):
 *         [link text]()
 *
 *         so we're stripping out the angle brackets to leave this:
 *         [link text](http://some.url/here)
 *
 *         which give us the correct link element (url+text).
 *
 * 3. sanitize-html is removing <some@email.com> formatted markup that
 *    is the recommended syntax in some documentation. This bit will
 *    filter for that syntax and convert to $mailtosome@email.com$mailto
 *    which will help to bypass sanitize-html (see step 5).
 *
 * 4. Converts unwanted HTML from input (when passed HTML or Markdown).
 *    Note: Because we're converting from Markup, we need to be careful
 *          about what is converted into entity or escaped form for
 *          that reason, we are trying to be minimalistic in approach.
 *
 * 5. To follow step 3 (and this must happen after step 4), we now filter
 *    for $mailtosome@email.com$mailto and replace with the original
 *    angle brackets to reset to <some@email.com> markdown. It's worth
 *    noting that, after saving, the markdown of <some@email.com> gets
 *    converted to [some@email.com](mailto:some@email.com) anyway.
 *
 * 6. Fix markdown to blockquote element conversion (broken by the
 *    sanitize-html) script converting bracket > into &gt; entity.
 **/
function cleanInput(input) {
  // 1.
  input = input.replace(/\n<!--.*?-->/mig, "");
  // 2.
  input = input.replace(/\]\(\<(.*?)\>\)/mig, "]($1)");
  // 3.
  input = input.replace(/\<([\w\-\.]+@{1}[\w\-\.]+)>/mig, "$mailto$1$mailto");
  // 4.
  input = sanitizeHtml(input);
  // 5.
  input = input.replace(/\$mailto([\w\-\.]+@{1}[\w\-\.]+)\$mailto/mig, "<$1>");
  // 6.
  input = input.replace(/\n&gt;(\s{1}.*?\n)/mig, "\n>$1");
  return input;
}

module.exports  = {
  convertToMarkdown: convertToMarkdown,
  convertToHtml: convertToHtml,
  cleanInput: cleanInput,
}
