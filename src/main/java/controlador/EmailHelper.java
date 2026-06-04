package controlador;

import java.util.Properties;
import java.util.concurrent.CompletableFuture;
import javax.mail.*;
import javax.mail.internet.*;

public class EmailHelper {
    
    // Correo personal en "Remitente" y contraseña de apliación generada a través de Google en la cuenta Gmail en "Password"
    private static final String REMITENTE = "francooalc@gmail.com";
    private static final String PASSWORD = "jeijtennduizlofx";

    public static void enviarCorreoActivacionAsync(String destinatario, String nombre, int idEmpleado, String token, String baseUrl) {
        // CompletableFuture ejecuta el envío en un hilo secundario automáticamente
        CompletableFuture.runAsync(() -> {
            try {
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true"); // TLS

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(REMITENTE, PASSWORD);
                    }
                });

                Message message = new MimeMessage(session);
                message.setFrom(new InternetAddress(REMITENTE));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
                message.setSubject("Activación de Cuenta - Sistema Hermes");

                String linkActivacion = baseUrl + "/EmpleadoServlet?accion=activar&id=" + idEmpleado + "&token=" + token;
                
                String html = "<div style='font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: auto; border: 1px solid #e2e8f0; border-radius: 10px;'>"
                            + "<h2 style='color: #1a3a5c;'>Bienvenido a Hermes</h2>"
                            + "<p>Hola <strong>" + nombre + "</strong>,</p>"
                            + "<p>Tu cuenta ha sido registrada en el sistema de inventario Hermes. Para poder iniciar sesión, necesitas confirmar tu dirección de correo electrónico.</p>"
                            + "<br>"
                            + "<a href='" + linkActivacion + "' style='background-color: #0d6efd; color: white; padding: 12px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;'>Activar mi cuenta</a>"
                            + "<br><br>"
                            + "<p style='color: #64748b; font-size: 12px;'>Si el botón no funciona, copia y pega el siguiente enlace en tu navegador:<br>" + linkActivacion + "</p>"
                            + "</div>";

                message.setContent(html, "text/html; charset=utf-8");
                Transport.send(message);
                
            } catch (Exception e) {
                System.out.println("Error enviando correo a: " + destinatario);
                e.printStackTrace();
            }
        });
    }
    
    public static void enviarCorreoRecuperacionAsync(String destinatario, String nombre, String token, String baseUrl) {
        CompletableFuture.runAsync(() -> {
            try {
                Properties props = new Properties();
                props.put("mail.smtp.host", "smtp.gmail.com");
                props.put("mail.smtp.port", "587");
                props.put("mail.smtp.auth", "true");
                props.put("mail.smtp.starttls.enable", "true");

                Session session = Session.getInstance(props, new Authenticator() {
                    @Override
                    protected PasswordAuthentication getPasswordAuthentication() {
                        return new PasswordAuthentication(REMITENTE, PASSWORD);
                    }
                });

                Message message = new MimeMessage(session);
                message.setFrom(new InternetAddress(REMITENTE));
                message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(destinatario));
                message.setSubject("Recuperación de Contraseña - Sistema Hermes");

                // Enlace que apunta al Servlet de recuperación
                String linkRecuperacion = baseUrl + "/RecuperacionServlet?accion=restablecer&token=" + token;

                String html = "<div style='font-family: Arial, sans-serif; padding: 20px; max-width: 600px; margin: auto; border: 1px solid #e2e8f0; border-radius: 10px;'>"
                        + "<h2 style='color: #d97706;'>Recuperación de Contraseña</h2>"
                        + "<p>Hola <strong>" + nombre + "</strong>,</p>"
                        + "<p>Has solicitado restablecer tu contraseña para el sistema <strong>Hermes</strong>. Si no fuiste tú, puedes ignorar este correo.</p>"
                        + "<br>"
                        + "<a href='" + linkRecuperacion + "' style='background-color: #d97706; color: white; padding: 12px 20px; text-decoration: none; border-radius: 6px; font-weight: bold; display: inline-block;'>Restablecer mi contraseña</a>"
                        + "<br><br>"
                        + "<p style='color: #64748b; font-size: 12px;'>Este enlace expirará en 15 minutos.</p>"
                        + "</div>";

                message.setContent(html, "text/html; charset=utf-8");
                Transport.send(message);

            } catch (Exception e) {
                System.out.println("Error enviando correo de recuperación a: " + destinatario);
                e.printStackTrace();
            }
        });
    }
}