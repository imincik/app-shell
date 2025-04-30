#include <stdio.h>
#include <curl/curl.h>

int main() {
    CURL *curl;

    curl = curl_easy_init();  // Initialize libcurl
    if (curl) {
        printf("It works !\n");
        // curl_easy_cleanup(curl);     // Cleanup
    } else {
        printf("libcurl failed to initialize.\n");
    }
    return 0;
}
