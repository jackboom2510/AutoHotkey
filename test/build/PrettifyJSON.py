import json

def format_json_single_line_arrays(input_path, output_path, indent=4):
    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    def is_primitive(val):
        return not isinstance(val, (list, dict))

    def is_simple_array(val):
        """Array chỉ chứa primitive, không lồng sâu."""
        return (
            isinstance(val, list) and
            all(is_primitive(x) for x in val)
        )

    def is_flat_array(arr):
        """
        Array mà mỗi phần tử là:
        - Primitive
        - Hoặc array con đơn giản (simple array).
        """
        if not isinstance(arr, list):
            return False
        if len(arr) == 0:
            return True  # Cho phép array rỗng
        return all(
            is_primitive(item) or is_simple_array(item)
            for item in arr
        )

    def is_array_of_flat_arrays(arr):
        """Array mà mỗi phần tử là array con flat theo định nghĩa trên."""
        return isinstance(arr, list) and all(
            isinstance(item, list) and is_flat_array(item)
            for item in arr
        )

    def format_obj(obj, level=0):
        pad = ' ' * indent * level
        if isinstance(obj, dict):
            items = [
                f"{' ' * indent * (level + 1)}{json.dumps(k, ensure_ascii=False)}: {format_obj(v, level + 1)}"
                for k, v in obj.items()
            ]
            return '{\n' + ',\n'.join(items) + '\n' + pad + '}'

        elif isinstance(obj, list):
            if is_flat_array(obj):
                return '[' + ', '.join(format_obj(item, 0) for item in obj) + ']'
            elif is_array_of_flat_arrays(obj):
                lines = [
                    ' ' * indent * (level + 1) + '[' + ', '.join(format_obj(subitem, 0) for subitem in item) + ']'
                    for item in obj
                ]
                return '[\n' + '\n'.join(lines) + '\n' + pad + ']'
            else:
                lines = [
                    ' ' * indent * (level + 1) + format_obj(item, level + 1)
                    for item in obj
                ]
                return '[\n' + ',\n'.join(lines) + '\n' + pad + ']'

        else:
            return json.dumps(obj, ensure_ascii=False)

    result = format_obj(data)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(result)

format_json_single_line_arrays("C:\\Users\\jackb\\Documents\\AutoHotkey\\configs\\test.json",
                               "C:\\Users\\jackb\\Documents\\AutoHotkey\\configs\\test.json")