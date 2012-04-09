<?php
class Erreur  extends Exception {
    
    public function __construct($Msg) {
        parent :: __construct($Msg);
    }
    
    public function RetourneErreur() {
        $msg  = '<div><strong>' . $this->getMessage() . '</strong>';
        $msg .= ' Line : ' . $this->getLine() . '</div>';
        return $msg;
    }
}
?>