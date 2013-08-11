function sendmailgmail(mail,password,destiny,title,message)
%SENDMAILGMAIL   Sends error alerts through email.
%
% Input:
%   mail: Email address.
%   password: Email password.
%   destiny: Destiny email address(es).
%   title: Email subject.
%   message: Email body containing error messages.
%
% Example:
%   sendmailgmail('sfmunera@gmail.com','abc123','ccartagena89@gmail.com','Transfer Error',':(')

% Written by 
% Sebastian Munera Alvarez and 
% Cesar Augusto Cartagena Ocampo 
% for the HORUS Project
% Universidad Nacional de Colombia
%   Copyright 2012 HORUS
%   $Date: 2012/08/04 12:39 $

try
    
    setpref('Internet','E_mail',mail);
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','SMTP_Username',mail);
    setpref('Internet','SMTP_Password',password);
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    sendmail(destiny,title,message)
    
catch e
    disp(e.message)
end