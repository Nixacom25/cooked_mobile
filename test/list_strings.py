import re

def list_strings():
    with open('assets/onboarding/cooked.riv', 'rb') as f:
        data = f.read()
    
    # Find all printable ASCII strings of length 3 to 40
    strings = re.findall(b'[a-zA-Z_][a-zA-Z0-9_]{2,39}', data)
    unique_strings = sorted(list(set(s.decode('utf-8') for s in strings)))
    
    interesting_patterns = [
        r'(?i)done', r'(?i)ready', r'(?i)scan', r'(?i)success', r'(?i)final', 
        r'(?i)pick', r'(?i)complete', r'(?i)step', r'(?i)check', r'(?i)match', 
        r'(?i)meal', r'(?i)prefer', r'(?i)loading', r'(?i)active', r'(?i)state',
        r'(?i)input', r'(?i)progress', r'(?i)is_', r'(?i)trigger'
    ]
    
    found = []
    for s in unique_strings:
        if any(re.search(pat, s) for pat in interesting_patterns):
            found.append(s)
            
    print("Interesting strings found:")
    for s in found:
        print(s)

if __name__ == '__main__':
    list_strings()
