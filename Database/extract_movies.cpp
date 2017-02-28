#include <cassert>
#include <iostream>
#include <fstream>
#include <regex>
#include <string>
using namespace std;

static regex movie_regex("\\[Category[^\\]]+(Films|films|片|電影|电影)(\\]|\\|)");

template<size_t N>
static const char* after_prefix(string& str, const char (&prefix)[N]) {
    // Subtract 1 to account for the terminating \0.
    return str.compare(0, N - 1, prefix) ? nullptr : str.c_str() + N - 1;
}

static void parse_text(string& text) {
    string line;
    
    while (getline(cin, line)) {
        auto length = line.rfind("</text>");
        if (length == line.npos) {
            text += line;
            text += "\n";
        }
        else {
            text += line.substr(0, length);
            text += "\n";
            break;
        }
    }
}

static void parse_page(string outdir) {
    string line, filename, text;
    
    while (getline(cin, line)) {
        if (line == "  </page>") {
            assert (!filename.empty());
            
            if (regex_search(text, movie_regex)) {
                ofstream stream(filename);
                stream << text;
            }
            
            return;
        }
        
        if (auto ns = after_prefix(line, "    <ns>")) {
            // We are only interested in namespace 0 (normal articles).
            if (atoi(ns) != 0) return;
        }
        
        if (auto id = after_prefix(line, "    <id>")) {
            filename = outdir + "/" + to_string(atoi(id)) + ".txt";
        }
        
        if (auto suffix = after_prefix(line, "    <title>")) {
            text = suffix;
            auto length = text.rfind("</title>");
            assert (length != text.npos);
            text.resize(length);
            text += "\n";
        }
        
        if (auto suffix = after_prefix(line, "      <text xml:space=\"preserve\">")) {
            // We are not interested in pages where the whole text fits in one line.
            if (strstr(suffix, "</text>")) return;
            
            text.reserve(1024 * 10);
            text += suffix;
            text += "\n";
            parse_text(text);
        }
    }
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        fprintf(stderr, "Usage: %s <output-dir>\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    // See http://stackoverflow.com/a/9371717
    ios_base::sync_with_stdio(false);
    
    string line;

    while (getline(cin, line)) {
        if (line == "  <page>") {
            parse_page(argv[1]);
        }
    }
}


