package cicd.api;


import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/devops")
public class Welcome {

	@GetMapping
	public ResponseEntity<String> greet() {
		
		return new ResponseEntity<>("Welcome to devops/jenkins learning...1", HttpStatus.OK);
	}
	
	@GetMapping("developer")
	public ResponseEntity<String> developer() {
		
		return new ResponseEntity<>("Welcome to devops/jenkins learning...for developers", HttpStatus.OK);
	}
}
