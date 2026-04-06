#Include <core\Log>
#Include <ui\Notify>

IsFunc(this) {
    return this is Func
}

IndexOf(this, value, startIndex := 1) {
    for i, v in this
        if (i >= startIndex && v = value)
            return i
    return 0
}

Slice(this, start := 1, end := "") {
    out := []
    if (end = "")
        end := this.Length
    if (start < 0)
        start := this.Length + start + 1
    if (end < 0)
        end := this.Length + end + 1
    loop end - start + 1
        out.Push(this[start + A_Index - 1])
    return out
}

Array_Contains(this, value) {
    return this.IndexOf(value) != 0
}

Array_Join(this, separator := ",", bracket := false) {
    str := bracket ? "[" : ""
    for i, v in this
        str .= (i > 1 ? separator : "") v
    str .= bracket ? "]" : ""
    return str
}

Array_RemoveValue(this, value, all := true) {
    removed := 0
    i := this.Length
    while (i >= 1) {
        if (this[i] = value) {
            this.RemoveAt(i)
            removed++
            if !all
                break
        }
        i--
    }
    return removed
}

Array_Count(this, predicate := "") {
    if !predicate
        return this.Length
    count := 0
    for v in this
        if predicate(v)
            count++
    return count
}

Array_Map(this, selector) {
    result := []
    for i, v in this
        result.Push(selector(v))
    return result
}

Array_Where(this, predicate) {
    result := []
    for v in this
        if predicate(v)
            result.Push(v)
    return result
}

Array_ToString(this, replacer := "", asJson := true, space := 4, _level := 0) {
    parts := []
    indent := space ? StrRepeat(" ", _level * space) : ""
    nl := space ? "`n" : ""

    for k, v in this {
        if IsFunc(replacer)
            v := replacer(k, v)

        if IsObject(v) {
            if v is Array
                val := v.ToString(replacer, asJson, space, _level + 1)
            else if v is Map
                val := v.ToString(replacer, asJson, space, _level + 1)
            else
                val := asJson ? "null" : "<" Type(v) ">"
        } else {
            if asJson {
                if IsNumber(v)
                    val := v
                else
                    val := '"' StrReplace(v, '"', '\"') '"'
            } else {
                val := v
            }
        }
        parts.Push(val)
    }

    if asJson && space {
        ; Dùng _level+1 cho indent của nội dung, nhưng dòng đầu dùng indent chính
        inner := ""
        innerIndent := StrRepeat(" ", (_level + 1) * space)
        for i, v in parts
            inner .= (i > 1 ? "," nl : "") innerIndent v
        return "[" nl inner nl indent "]"
    } else if asJson
        return "[" parts.Join(",") "]"
    else
        return "[" parts.Join(",") "]"
}

Map_ToString(this, replacer := "", asJson := true, space := 4, _level := 0) {
    parts := []
    indent := space ? StrRepeat(" ", _level * space) : ""
    nl := space ? "`n" : ""

    for key, value in this {
        keyStr := asJson ? '"' StrReplace(key, '"', '\"') '"' : key

        if IsFunc(replacer)
            value := replacer(key, value)

        if IsObject(value) {
            if value is Array
                val := value.ToString(replacer, asJson, space, _level + 1)
            else if value is Map
                val := value.ToString(replacer, asJson, space, _level + 1)
            else
                val := asJson ? "null" : "<" Type(value) ">"
        } else {
            if asJson {
                if IsNumber(value)
                    val := value
                else
                    val := '"' StrReplace(value, '"', '\"') '"'
            } else
                val := value
        }
        parts.Push(keyStr ": " val)
    }

    if asJson && space {
        inner := ""
        innerIndent := StrRepeat(" ", (_level + 1) * space)
        for i, v in parts
            inner .= (i > 1 ? "," nl : "") innerIndent v
        return "{" nl inner nl indent "}"
    } else if asJson
        return "{" parts.Join(",") "}"
    else
        return "{" parts.Join(",") "}"
}

Array.Prototype.DefineProp("IndexOf", { Call: IndexOf })
Array.Prototype.DefineProp("Slice", { call: Slice })
Array.Prototype.DefineProp("Contains", { Call: Array_Contains })
Array.Prototype.DefineProp("Join", { Call: Array_Join })
Array.Prototype.DefineProp("RemoveValue", { Call: Array_RemoveValue })
Array.Prototype.DefineProp("Count", { Call: Array_Count })
Array.Prototype.DefineProp("Map", { Call: Array_Map })
Array.Prototype.DefineProp("Where", { Call: Array_Where })
Array.Prototype.DefineProp("ToString", { Call: Array_ToString })
Map.Prototype.DefineProp("ToString", { Call: Map_ToString })