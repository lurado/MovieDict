#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

%%{
    machine extract_movies;
    write data;
}%%

int main(int argc, char *argv[]) {
    if (argc != 3) {
        fprintf(stderr, "Usage: %s <path to enwiki-*-pages-articles-multistream.xml> <output-dir>\n", argv[0]);
        return EXIT_FAILURE;
    }
    
    int fd = open(argv[1], O_RDONLY);
    if (fd < 0) {
        fprintf(stderr, "Cannot find input file %s\n", argv[1]);
        return EXIT_FAILURE;
    }
    
    off_t file_size = lseek(fd, 0, SEEK_END);
    lseek(fd, 0, SEEK_SET);

    char const *p = mmap(NULL, file_size, PROT_READ, MAP_NOCACHE | MAP_SHARED, fd, 0);
    if (p == MAP_FAILED) {
        perror(strerror(errno));
        return EXIT_FAILURE;
    }
        
    // Variables needed by ragel, in addition to 'p'
    char const* pe = p + file_size;
    int cs = 0;
    
    // My own bookkeeping
    int movie_category_links;
    char const *title_begin = NULL, *title_end = NULL;
    char const *id_begin = NULL; // atoi() doesn't need end
    char const *text_begin = NULL, *text_end = NULL;
    
    %%{
        action begin_page {
            movie_category_links = 0;
        }
        
        action begin_title {
            title_begin = fpc;
        }
        
        action end_title {
            title_end = fpc;
        }
        
        action check_namespace {
            if (fc != '0') {
                // Reset title_begin - this will ensure that this page is not used
                title_begin = NULL;
            }
        }
        
        action begin_id {
            id_begin = fpc;
        }
        
        action mark_as_movie {
            movie_category_links += 1;
        }
        
        action begin_text {
            text_begin = fpc;
        }
        
        action end_text {
            text_end = fpc;
        }
        
        action end_page {
            if (title_begin && movie_category_links > 0) {
                char filename[1024];
                snprintf(filename, 1024, "%s/%d.txt", argv[2], atoi(id_begin));
                int page_fd = open(filename, O_WRONLY|O_CREAT|O_TRUNC, 0664);
                if (page_fd < 0) {
                    fprintf(stderr, "Cannot write file %s - skipping\n", filename);
                }
                else {
                    write(page_fd, title_begin, title_end - title_begin);
                    write(page_fd, "\n", 1);
                    write(page_fd, text_begin, text_end - text_begin);
                    fsync(page_fd);
                    close(page_fd);
                }
            }
        }
        
        main := '<mediawiki ' any* '</siteinfo>'
                  (space* '<page>'@begin_page
                    space* '<title>' ((any - '<')* >begin_title%end_title) '</title>'
                    space* '<ns>' (digit+ >check_namespace) '</ns>'
                    space* '<id>' (digit+ >begin_id) '</id>'
                    any*   '<text xml:space="preserve">'
                        ((('[Category' (any - ']')+ ('Films'|'films'|'片'|'電影'|'电影')']')@mark_as_movie | any)* >begin_text%end_text)
                           '</text>'
                    any* '</page>'@end_page)*
                 '</mediawiki>';
    
        # Initialize and execute.
        write init;
        write exec;
    }%%

    return 0;
}
