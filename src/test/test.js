const selectedCategory = "{lv=category}";
const selectedCharacter = {
    character: "{lv=character}",
    summary: "{lv=summary}"
};
const characterList = `{lv=list}`;
const styleConfigJSON = `{lv=styleConfigJSON}`;
const skipCategoriesRaw = `{lv=skipCategories}`;

// Parse style config JSON or use fallback
let styleConfig = {};
try {
    styleConfig = JSON.parse(styleConfigJSON);
} catch (e) {
    console.warn("JSON lỗi, dùng mặc định");
    styleConfig = {
        title: {
            color: "#FAB12F",
            categoryColor: "#99CCFF",
            fontSize: "0.85em"
        },
        list: {
            ulMargin: "0",
            ulPaddingLeft: "1.2em",
            ulLineHeight: "1.25",
            liMargin: "0",
            liPadding: "0",
            selectedCharacterSeparator: " - "
        },
        character: {
            nameColor: "#4DD0E1",
            infoColor: "#CCCCCC"
        }
    };
}

// Parse skipCategories (Multi-line indexed format)
const skipCategories = [];
for (const line of skipCategoriesRaw.split(/\r?\n/)) {
    const match = line.match(/^\[\d+\]:\s*(.+)$/);
    if (match) skipCategories.push(match[1].trim().toLowerCase());
}

// Format list with categories
function formatListWithCategory(listString, style, skipCategories) {
    const lines = listString.split(/\r?\n/).map(l => l.trim()).filter(l => l);
    let html = '';
    let currentCat = '';
    let items = [];

    const flushCategory = () => {
        if (currentCat && items.length && !skipCategories.includes(currentCat.toLowerCase())) {
            html += `<font style="font-size:${style.title.fontSize}" color="${style.title.categoryColor}"><b>[${currentCat}]</b></font>`;
            html += `<ul style="margin:${style.list.ulMargin}; padding-left:${style.list.ulPaddingLeft}; line-height:${style.list.ulLineHeight}; font-size:${style.title.fontSize};">`;
            html += items.join('');
            html += `</ul>`;
        }
        items = [];
    };

    for (const line of lines) {
        const catMatch = line.match(/^\[([^\]]+)\]:\s*$/);
        if (catMatch) {
            flushCategory();
            currentCat = catMatch[1];
            continue;
        }

        if (line.startsWith('--')) {
            const match = line.match(/^-- \[([^\]]+)\]:\s*(.*)$/);
            if (match) {
                const name = match[1].trim();
                const summary = match[2].trim();
                items.push(
                    `<li style="margin:${style.list.liMargin}; padding:${style.list.liPadding};">` +
                    `<span style="color:${style.character.nameColor};"><b>${name}</b></span>` +
                    `${style.list.selectedCharacterSeparator}` +
                    `<i style="color:${style.character.infoColor};">${summary}</i></li>`
                );
            }
        }
    }
    flushCategory();
    return html;
}

// Format list without categories
function formatCharacterListOnly(listString, style) {
    const lines = listString.split(/\r?\n/).map(l => l.trim()).filter(l => l);
    let html = `<ul style="margin:${style.list.ulMargin}; padding-left:${style.list.ulPaddingLeft}; line-height:${style.list.ulLineHeight}; font-size:${style.title.fontSize};">`;

    for (const line of lines) {
        const match = line.match(/^\[([^\]]+)\]:\s*(.*)$/);
        if (match) {
            const name = match[1].trim();
            const summary = match[2].trim();
            html += `<li style="margin:${style.list.liMargin}; padding:${style.list.liPadding};">` +
                `<span style="color:${style.character.nameColor};"><b>${name}</b></span>` +
                `${style.list.selectedCharacterSeparator}` +
                `<i style="color:${style.character.infoColor};">${summary}</i></li>`;
        }
    }
    html += '</ul>';
    return html;
}

// Main formatter
function formatCharacterBlock(category, selected, listString, skipCategories, style) {
    let html = '';
    html += `<div class="recently-added-block" style="font-size:${style.title.fontSize};">`;
    html += `<font style="font-size:${parseFloat(style.title.fontSize)}" color="${style.title.color}"><b>Recently Added</b></font><br>`;
    html += `<font style="font-size:${style.title.fontSize}" color="${style.title.categoryColor}"><b>[${category}]</b></font><br>`;
    html += `<span style="color:${style.character.nameColor};"><b>${selected.character}</b></span>` +
        `${style.list.selectedCharacterSeparator}` +
        `<i style="color:${style.character.infoColor};">${selected.summary}</i><br>`;
    html += `</div>`;

    html += `<div class="recently-added-block" style="font-size:${style.title.fontSize};">`;
    html += `<font style="font-size:${parseFloat(style.title.fontSize)}" color="${style.title.color}"><b>All Characters</b></font><br>`;

    if (/--\s\[[^\]]+\]:/.test(listString))
        html += formatListWithCategory(listString, style, skipCategories);
    else
        html += formatCharacterListOnly(listString, style);

    html += `</div>`;
    return html;
}

const htmlOutput = formatCharacterBlock(selectedCategory, selectedCharacter, characterList, skipCategories, styleConfig);
console.log(htmlOutput);