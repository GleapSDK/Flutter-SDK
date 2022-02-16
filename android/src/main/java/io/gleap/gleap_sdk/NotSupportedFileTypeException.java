package io.gleap.gleap_sdk;

public class NotSupportedFileTypeException extends Exception{
    public NotSupportedFileTypeException() {
        super("Filetype not supported.");
    }
}
