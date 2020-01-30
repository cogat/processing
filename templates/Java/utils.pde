import java.util.Date;
import java.text.DateFormat;
import java.text.SimpleDateFormat;

String date_string() {
  DateFormat df = new SimpleDateFormat("yyyyMMdd-HHmmss");
  return df.format(new Date());
}
