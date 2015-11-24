# Taken from http://wiki.bits.vib.be/index.php/NGS_Exercise.5_GATK#Obtain_the_required_gatk_bundle_reference_files

# Files needed to run mutect

# ftp settings
ftpusr=gsapubftp-anonymous
bundleurl=ftp.broadinstitute.org
bundlepath=/bundle/2.8/hg19
 
# local settings
bundle=bundle_2.8
mkdir -p ${bundle}
 
# create a list of files to download
LIST=$(cat <<'END_HEREDOC'
dbsnp_138.hg19.vcf.gz
END_HEREDOC
)
 
# download each LIST file 
for file in ${LIST}; do
# download is absent
[ -f "${bundle}/${file}" ] || wget -np -P ${bundle} --ftp-user=${ftpusr} ${bundleurl}:${bundlepath}/${file}
# convert gzip to bgzip to unable tabix indexing
gunzip ${file}
bgzip ${file%%.gz}
# index with tabix
tabix -p vcf ${bundle}/${file}
done
 
# create a list of reference files to download
LIST2=$(cat <<'END_HEREDOC'
ucsc.hg19.fasta.gz
ucsc.hg19.fasta.fai.gz
ucsc.hg19.dict.gz
END_HEREDOC
)
 
# download each LIST2 file 
for file in ${LIST2}; do
# download is absent
[ -f "${bundle}/${file}" ] || wget -np -P ${bundle} --ftp-user=${ftpusr} ${bundleurl}:${bundlepath}/${file}
gunzip ${file}
done
