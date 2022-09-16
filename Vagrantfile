domain = "kubernetes.lab"
pod_network_cidr = "10.244.0.0/16"
pod_network_type = "calico" # choose between calico and flannel
master_node_ip = "192.168.57.100"
metallb_address_pool = "192.168.57.200 - 192.168.57.240"
version = "1.24.4-00"

Vagrant.configure("2") do |config|
    config.ssh.insert_key = false
    config.vm.provision :shell, path: "kubeadm/bootstrap.sh", env: { "VERSION" => version }
    config.vm.provision :shell, path: "helm/install.sh"
    (0..2).each do |nodeIndex|
      config.vm.provision "shell", env: {"DOMAIN" => domain, "NODE_INDEX" => nodeIndex}, inline: <<-SHELL 
        echo "192.168.57.10$NODE_INDEX node-$NODE_INDEX.$DOMAIN node-$NODE_INDEX" >> /etc/hosts 
        SHELL
    end
    config.vm.define "master" do |master|
      master.vm.box = "ubuntu/focal64"
      master.vm.hostname = "node-0.#{domain}"
      master.vm.network "private_network", ip: "#{master_node_ip}"
      master.vm.provision "shell", path:"kubeadm/init-master.sh", env: {"K8S_POD_NETWORK_CIDR" => pod_network_cidr, "K8S_POD_NETWORK_TYPE" => pod_network_type, "MASTER_NODE_IP" => master_node_ip}
      master.vm.provision "shell", path:"longhorn/bootstrap.sh"

      # master.vm.provision "shell", path:"helm/install.sh"
      # master.vm.provision "shell", path:"longhorn/bootstrap.sh"
      # master.vm.provision "shell", path:"longhorn/install.sh"
      # master.vm.provision "shell", path:"metallb/deployment/install.sh", env: {"METALLB_ADDRESS_POOL" => metallb_address_pool }
    end
    (1..2).each do |nodeIndex|
      config.vm.define "worker-#{nodeIndex}" do |worker|
        worker.vm.box = "ubuntu/focal64"
        worker.vm.hostname = "node-#{nodeIndex}.#{domain}"
        worker.vm.network "private_network", ip: "192.168.57.10#{nodeIndex}"
        worker.vm.provision "shell", path:"kubeadm/init-worker.sh"
        worker.vm.provision "shell", env: { "NODE_INDEX" => nodeIndex}, inline: <<-SHELL 
            
            echo ">>> FIX KUBELET NODE IP"
            echo "Environment=\"KUBELET_EXTRA_ARGS=--node-ip=192.168.57.10$NODE_INDEX\"" | sudo tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
            sudo systemctl daemon-reload
            sudo systemctl restart kubelet

            echo ">>> CONFIGURE KUBECTL"

            sudo mkdir -p $HOME/.kube
            sudo cp -i /etc/kubernetes/kubelet.conf $HOME/.kube/config
            sudo chown $(id -u):$(id -g) $HOME/.kube/config

            mkdir -p /home/vagrant/.kube
            sudo cp -f /etc/kubernetes/kubelet.conf /home/vagrant/.kube/config
            sudo chown $(id -u):$(id -g) /home/vagrant/.kube/config

            # ./vagrant/kubeadm/kubectl.sh

            SHELL
        worker.vm.provision "shell", path:"longhorn/bootstrap.sh" 

        if nodeIndex == 2
          worker.vm.provision "shell", env: { "NODE_INDEX" => nodeIndex}, inline: <<-SHELL 
            echo ">>> WAITING COREDNS, POD-NETWORK, KUBE-PROXY PODS TO GET READY (2m0)"
            sleep 180
            SHELL

          worker.vm.provision "shell", path:"longhorn/install.sh"
          worker.vm.provision "shell", path:"metallb/deployment/install.sh", env: {"METALLB_ADDRESS_POOL" => metallb_address_pool }
        else
        end

      end
    end
    config.vm.provider "virtualbox" do |vb|
      vb.memory = "3072"
      vb.cpus = "1"
      vb.customize ["modifyvm", :id, "--nic1", "nat"]
    end
  end


  