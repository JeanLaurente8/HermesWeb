package servicios;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

public class DniApiService {

    private static final String TOKEN = "25811a0dd224308e4ba07e6c13993548";

    public String consultarDni(String dni) {

        try {
            String url = "https://peruapi.com/api/dni/" + dni + "?api_token=" + TOKEN;

            HttpClient client = HttpClient.newHttpClient();

            HttpRequest request = HttpRequest.newBuilder().uri(URI.create(url)).GET().build();

            HttpResponse<String> response = client.send(request, HttpResponse.BodyHandlers.ofString());

            if (response.statusCode() == 200) {
                return response.body();
            }

            return null;

        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}