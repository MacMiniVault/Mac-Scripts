Description :

          This utility is designed to connect to multiple servers in your organization's, home,
          or client's network and provide you, the possible system administrator with a somewhat 
          detailed report on the system.
          
          Version 1.0 - Created by Bradley Massey

Usage : 

          1. You will have to change the 'in-line' IP's in the for $ip loop
          2. Duplicate shell for each pretendco*.sh you desire a report for
          3. Scheducle the shells to run at certain moments in time
          4. Optionally comment out the 2nd for loop or modify for IP's that only require a ping.
          
          Get a report for all IP's declared in pretendco*.sh :
          
          Connect to VPN if necessary.
          ~$ . pretendco*.sh
          ~$ main > /Path/to/output/file.txt
          
Best Practices : 

          1. Create a id_rsa.pub without a password (~$ man ssh_keygen)
          2. Append your id_rsa.pub key to /var/root/.ssh/authorized_keys
          
          This provides for secure access without the necessity of authentification upon each
          attempt. Practical in environments with multiple servers each having a unique 
          password.

Parameters :

          This command does not take any parameters.
